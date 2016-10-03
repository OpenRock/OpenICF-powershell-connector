/*
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
 *
 * Copyright (c) 2014-2016 ForgeRock AS. All Rights Reserved
 *
 * The contents of this file are subject to the terms
 * of the Common Development and Distribution License
 * (the License). You may not use this file except in
 * compliance with the License.
 *
 * You can obtain a copy of the License at
 * http://forgerock.org/license/CDDLv1.0.html
 * See the License for the specific language governing
 * permission and limitations under the License.
 *
 * When distributing Covered Code, include this CDDL
 * Header Notice in each file and include the License file
 * at http://forgerock.org/license/CDDLv1.0.html
 * If applicable, add the following below the CDDL Header,
 * with the fields enclosed by brackets [] replaced by
 * your own identifying information:
 * "Portions Copyrighted [year] [name of copyright owner]"
 */

using System;
using System.Collections;
using System.Collections.Generic;
using Org.IdentityConnectors.Framework.Common.Objects.Filters;

namespace Org.ForgeRock.OpenICF.Connectors.MsPowerShell
{
    public class MapFilterVisitor : FilterVisitor<Dictionary<string, Object>, Dictionary<string, string>>
    {
        private const string Not = "Not";
        private const string Operation = "Operation";
        private const string Left = "Left";
        private const string Right = "Right";
        private const string And = "And";
        private const string Or = "Or";

        public Dictionary<string, object> VisitAndFilter(Dictionary<string, string> p, AndFilter filter)
        {
            var dic = new Dictionary<string, object>
            {
                {Not, false},
                {Left, filter.Left.Accept<Dictionary<string, object>, Dictionary<string, string>>(this, p)},
                {Right, filter.Right.Accept<Dictionary<string, object>, Dictionary<string, string>>(this, p)},
                {Operation, And}
            };
            return dic;
        }

        public Dictionary<string, object> VisitContainsFilter(Dictionary<string, string> p, ContainsFilter filter)
        {
            string name = filter.GetName();
            if (p.ContainsKey(name))
            {
                name = p[name];
            }
            return CreateMap("CONTAINS", name, filter.GetValue());
        }

        public Dictionary<string, object> VisitContainsAllValuesFilter(Dictionary<string, string> p, ContainsAllValuesFilter filter)
        {
            throw new NotImplementedException();
        }

        public Dictionary<string, object> VisitEqualsFilter(Dictionary<string, string> p, EqualsFilter filter)
        {
            string name = filter.GetAttribute().Name;
            if (p.ContainsKey(name))
            {
                name = p[name];
            }
            var values = filter.GetAttribute().Value;
            if (values.Count == 1)
            {
                return CreateMap("EQUALS", name, values[0]);
            }
            throw new NotImplementedException("Equality visitor does not implement multi value attribute");
        }

        public Dictionary<string, object> VisitExtendedFilter(Dictionary<string, string> p, Filter filter)
        {
            throw new NotImplementedException();
        }

        public Dictionary<string, object> VisitGreaterThanFilter(Dictionary<string, string> p, GreaterThanFilter filter)
        {
            string name = filter.GetName();
            if (p.ContainsKey(name))
            {
                name = p[name];
            }
            return CreateMap("GREATERTHAN", name, filter.GetValue());
        }

        public Dictionary<string, object> VisitGreaterThanOrEqualFilter(Dictionary<string, string> p, GreaterThanOrEqualFilter filter)
        {
            string name = filter.GetName();
            if (p.ContainsKey(name))
            {
                name = p[name];
            }
            return CreateMap("GREATERTHANOREQUAL", name, filter.GetValue());
        }

        public Dictionary<string, object> VisitLessThanFilter(Dictionary<string, string> p, LessThanFilter filter)
        {
            string name = filter.GetName();
            if (p.ContainsKey(name))
            {
                name = p[name];
            }
            return CreateMap("LESSTHAN", name, filter.GetValue());
        }

        public Dictionary<string, object> VisitLessThanOrEqualFilter(Dictionary<string, string> p, LessThanOrEqualFilter filter)
        {
            string name = filter.GetName();
            if (p.ContainsKey(name))
            {
                name = p[name];
            }
            return CreateMap("LESSTHANOREQUAL", name, filter.GetValue());
        }

        public Dictionary<string, object> VisitNotFilter(Dictionary<string, string> p, NotFilter filter)
        {
            var dic = filter.Accept<Dictionary<string, object>, Dictionary<string, string>>(this, p);
            dic[Not] = true;
            return dic;
        }

        public Dictionary<string, object> VisitOrFilter(Dictionary<string, string> p, OrFilter filter)
        {
            var dic = new Dictionary<string, object>
            {
                {Not, false},
                {Left, filter.Left.Accept<Dictionary<string, object>, Dictionary<string, string>>(this, p)},
                {Right, filter.Right.Accept<Dictionary<string, object>, Dictionary<string, string>>(this, p)},
                {Operation, Or}
            };
            return dic;
        }

        public Dictionary<string, object> VisitStartsWithFilter(Dictionary<string, string> p, StartsWithFilter filter)
        {
            string name = filter.GetName();
            if (p.ContainsKey(name))
            {
                name = p[name];
            }
            return CreateMap("STARTSWITH", name, filter.GetValue());
        }

        public Dictionary<string, object> VisitEndsWithFilter(Dictionary<string, string> p, EndsWithFilter filter)
        {
            string name = filter.GetName();
            if (p.ContainsKey(name))
            {
                name = p[name];
            }
            return CreateMap("ENDSWITH", name, filter.GetValue());
        }

        private static Dictionary<string, object> CreateMap(string operation, string name, object value)
        {
            var dic = new Dictionary<string, object>();
            if (value == null)
            {
                return null;
            }
            dic.Add(Not, false);
            dic.Add(Operation, operation);
            dic.Add(Left, name);
            dic.Add(Right, value);
            return dic;
        }
    }
}
